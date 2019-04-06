plan barcamp(
  String $tf_path,
  Integer $count = 2
) {
  $localhost = get_targets('localhost')

  # If we haven't already done this
  if empty(get_targets('dashboard')) {
    # Run terraform-apply
    run_command("cd ${$tf_path} && terraform apply -no-color -auto-approve -var 'instances=${$count}'", $localhost)

    # Get the IPs of the cloud resources created
    $result = run_command("cd ${$tf_path} && terraform output public_ips", $localhost).first.value
    # Turn those IPs into Bolt targets
    $nodes = $result['stdout'].split(",").map |$t| { Target.new($t.strip) }

    add_to_group($nodes[0], 'dashboard')
    add_to_group($nodes, 'agents')
  } else {
    $nodes = get_targets('agents').map |$t| { $t.name }
  }

  $dashboard_host = get_targets('dashboard')[0].name

  apply_prep('all')

  apply('dashboard') {
    include barcamp::dashboard
  }

  apply('agents') {
    class{ barcamp::telegraf:
      influx_host => $dashboard_host
    }
  }

  return({
    'grafana_dashboard' => "http://${dashboard_host}:8080",
    'nodes' => $nodes })
}
