require 'spec_helper'

describe 'python' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with system version" do
        let(:params) {{
          :pip => false,
          :dev => false,
          :virtualenv => false,
          :version => 'system'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class("python::install") }

        context 'with dev' do
          let(:params) {{
            :version => 'system',
            :dev => true,
            :pip => false,
            :virtualenv => false,
          }}

          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_package('python-devel') }
          when 'Debian'
            it { is_expected.to contain_package('python-dev') }
          else
          end
        end

        context 'with pip' do
          let(:params) {{
            :version => 'system',
            :pip => true,
            :dev => false,
            :virtualenv => false,
          }}

          case facts[:kernel]
          when 'Linux'
            it { is_expected.to contain_package('python-pip') }

          when 'FreeBSD'
            it { is_expected.to contain_package('py27-pip') }

          when 'OpenBSD'
            it { is_expected.to contain_package('py-pip') }

          else
            it { is_expected.to_not contain_package('py27-pip') }
            it { is_expected.to_not contain_package('python-pip') }
            it { is_expected.to_not contain_package('python3-pip') }
          end

        end

        context 'with virtualenv' do 
          let(:params) {{
            :version => 'system',
            :virtualenv => true,
            :dev => false,
            :pip => false,
          }}

          case facts[:operatingsystem]
          when 'Debian'
            it { is_expected.to contain_package('python-virtualenv') }

          when 'FreeBSD'
            it { is_expected.to contain_package('py27-virtualenv') }

          when 'OpenBSD'
            it { is_expected.to contain_package('py-virtualenv') }

          else
          end
        end

      end

      context "with python3" do
        three_versions(facts).each{|three_version|
          context "version #{three_version}" do
            if three_version.nil?
              puts "skipping python3 tests on #{facts[:os]}"
              next
            end

            let(:params) {{
              :pip => false,
              :dev => false,
              :virtualenv => false,
              :version => three_version,
            }}
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class("python::install") }

            case facts[:osfamily]
            when 'OpenBSD'
              it { is_expected.to contain_package('python').with_ensure(three_version)}

            when 'FreeBSD'
              case three_version
              when '34'
                it { is_expected.to contain_package('python34')}

              when '35'
                it { is_expected.to contain_package('python35')}

              end
            when 'Debian'
              it { is_expected.to contain_package('python3.4')}

            when 'Archlinux'
              it { is_expected.to contain_package('python') }

            when 'RedHat'
            end
          end

          context 'when dev enabled is enabled' do
            let(:params) {{
              :pip => false,
              :dev => true,
              :virtualenv => false,
              :version => three_version,
            }}

            case facts[:osfamily]
            when 'RedHat'
              it { is_expected.to contain_package('python3-devel') }
            when 'Debian'
              it { is_expected.to contain_package('python3.4-dev') }
            else
            end
          end


          context 'when pip is enabled' do
            let(:params) {{
              :pip => true,
              :dev => false,
              :virtualenv => false,
              :version => three_version,
            }}

            case facts[:osfamily]
            when 'RedHat'
              case facts[:operatingsystemmajrelease]
              when '7'
                it { is_expected.to contain_exec('install_pip3').with_command('/bin/curl https://bootstrap.pypa.io/get-pip.py | /bin/python3')}
              end
            when 'Debian'
              it { is_expected.to contain_package('python3-pip') }

            when 'FreeBSD'
              case three_version
              when '34'
                it { is_expected.to contain_package("py34-pip") }

              when '35'
                it { is_expected.to contain_package("py35-pip") }

              end
            when 'OpenBSD'
              it { is_expected.to contain_package('py3-pip') }

            when 'Archlinux'
              it { is_expected.to contain_package('python-pip') }

            else
              it { is_expected.to_not contain_package('py27-pip') }
              it { is_expected.to_not contain_package('python-pip') }
            end
          end

          context 'when virtualenv is enabled' do
            let(:params) {{
              :pip => false,
              :dev => false,
              :virtualenv => true,
              :version => three_version,
            }}

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('python3-virtualenv') }

            when 'RedHat'
              it { is_expected.to raise_error() }

            when 'FreeBSD'
              case three_version
              when '34'
                it { is_expected.to contain_package('py34-virtualenv') }
              when '35'
                it { is_expected.to contain_package('py35-virtualenv') }

              end

            when 'OpenBSD'
              it { is_expected.to contain_package('py3-virtualenv') }

            when 'Archlinux'
              it { is_expected.to contain_package('python-virtualenv') }

            else
            end
          end

          context 'when virtualenv and pip are enabled' do
            let(:params) {{
              :pip => true,
              :dev => false,
              :virtualenv => true,
              :version => three_version,
            }}

            case facts[:osfamily]
            when 'RedHat'
              it { is_expected.to contain_package("virtualenv").with_provider('pip3') }
              it { is_expected.to_not contain_package("python3-virtualenv") }

            when 'FreeBSD'
              case three_version
              when '34'
                it { is_expected.to contain_package("py34-virtualenv") }
              when '35'
                it { is_expected.to contain_package("py35-virtualenv") }

              end
            when 'OpenBSD'
              it { is_expected.to contain_package('py3-virtualenv') }

            else
            end
          end


        }

      end

      context "with python2" do
        two_versions(facts).each{|two_version|
          context "version #{two_version}" do
            if two_version.nil?
              puts "skipping python3 tests on #{facts[:os]}"
              next
            end

            let(:params) {{
              :pip => false,
              :dev => false,
              :virtualenv => false,
              :version => two_version,
            }}
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class("python::install") }

            case facts[:osfamily]
            when 'OpenBSD'
              it { is_expected.to contain_package('python').with_ensure(two_version)}
            when 'FreeBSD'
              it { is_expected.to contain_package('python27')}
            when 'Debian'
              it { is_expected.to contain_package('python2.7')}
            when 'Archlinux'
              it { is_expected.to contain_package('python2') }
            when 'RedHat'
            end
          end

          context 'when dev enabled is enabled' do
            let(:params) {{
              :pip => false,
              :dev => true,
              :virtualenv => false,
              :version => two_version,
            }}

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('python2.7-dev') }
            when 'RedHat'
            else
            end
          end


          context 'when pip is enabled' do
            let(:params) {{
              :pip => true,
              :dev => false,
              :virtualenv => false,
              :version => two_version,
            }}

            case facts[:osfamily]
            when 'RedHat'
              case facts[:operatingsystemmajrelease]
              when '7'
                it { is_expected.to contain_exec('install_pip3').with_command('/bin/curl https://bootstrap.pypa.io/get-pip.py | /bin/python3')}
              end
            when 'Debian'
              it { is_expected.to contain_package('python-pip') }
            when 'FreeBSD'
              it { is_expected.to contain_package("py27-pip") }
            when 'OpenBSD'
              it { is_expected.to contain_package('py-pip') }
            when 'Archlinux'
              it { is_expected.to contain_package('python2-pip') }

            else
              it { is_expected.to_not contain_package('py27-pip') }
              it { is_expected.to_not contain_package('python-pip') }
            end
          end

          context 'when virtualenv is enabled' do
            let(:params) {{
              :pip => false,
              :dev => false,
              :virtualenv => true,
              :version => two_version,
            }}

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('python-virtualenv') }

            when 'RedHat'
              it { is_expected.to raise_error() }

            when 'FreeBSD'
              it { is_expected.to contain_package('py27-virtualenv') }

            when 'OpenBSD'
              it { is_expected.to contain_package('py-virtualenv') }

            when 'Archlinux'
              it { is_expected.to contain_package('python2-virtualenv') }

            else
            end
          end

          context 'when virtualenv and pip are enabled' do
            let(:params) {{
              :pip => true,
              :dev => false,
              :virtualenv => true,
              :version => two_version,
            }}

            case facts[:osfamily]
            when 'RedHat'
              it { is_expected.to contain_package("virtualenv").with_provider('pip') }
              it { is_expected.to_not contain_package("python-virtualenv") }

            when 'FreeBSD'
              it { is_expected.to contain_package("py27-virtualenv") }

            when 'OpenBSD'
              it { is_expected.to contain_package('py-virtualenv') }

            else
            end
          end


        }

      end


    end
  end

end
