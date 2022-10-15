class Data::SystemInfo
  IN_DOCKER = Shell::Seq.run("egrep -q 'docker|^0::/$' /proc/self/cgroup").success?

  def self.docker? : Bool
    IN_DOCKER
  end
end
  
