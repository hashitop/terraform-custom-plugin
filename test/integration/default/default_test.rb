testscript_path = "/home/vagrant/test.sh"
workspace_path = "/home/vagrant/tf-workspace"
flag_file = "/home/vagrant/tested.flag"

describe file(testscript_path) do
    it { should exist }
end

describe file(workspace_path) do
  it { should exist }
end

describe command(testscript_path) do
    its("exit_status") { should eq 0 }
    its("stdout") { should match 'external_ip = \b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' }
end

describe file(flag_file) do
    it { should exist }
end
