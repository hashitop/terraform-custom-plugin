testscript_path = "/home/vagrant/test.sh"
workspace_path = "/home/vagrant/tf-workspace"

describe file(testscript_path) do
    it { should exist }
end

describe file(workspace_path) do
  it { should exist }
end

describe command(testscript_path) do
    its("exit_status") { should eq 0 }
end

