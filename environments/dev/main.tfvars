dns_domain = "tek-nik.com."
env        = "dev"
vpc_id     = "vpc-82bd6eff"
subnets    = ["subnet-73f3732c", "subnet-7f830419"]
databases = {
  postgres = {
    allocated_storage = 10
    }
}

apps = {

  frontend = {
    instance_type = "t3.small"
    ports = {
      frontend = 80
    }
    lb = {
      lb_internal = false
      port        = 80
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

  auth-service = {
    instance_type = "t3.small"
    ports = {
      auth-service = 8081
    }
    lb = {
      lb_internal = true
      port        = 8081
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

  portfolio-service = {
    instance_type = "t3.small"
    ports = {
      portfolio-service = 8080
    }
    lb = {
      lb_internal = true
      port        = 8080
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

  analytics-service = {
    instance_type = "t3.small"
    ports = {
      analytics-service = 8000
    }
    lb = {
      lb_internal = true
      port        = 8000
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

}