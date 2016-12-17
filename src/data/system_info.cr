class Data::SystemInfo
  IN_DOCKER = Shell::Seq.run("grep -q docker /proc/self/cgroup").success?

  def self.docker? : Bool
    IN_DOCKER
  end
end
  
