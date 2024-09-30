terraform {
  source = "${get_repo_root()}/resources/modules/amis"
}

inputs = {
    k8s_version = "1.28"
}