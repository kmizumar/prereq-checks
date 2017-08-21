## Running with Ansible

Use Ansible to easily run the prereq checks script across a cluster and collect
the results. The easiest way is to have a simple `ansible.cfg` file like this:

    [defaults]
    hostfile = inventory/hosts
    host_key_checking = False
    roles_path = roles

Update the inventory file to list the cluster hosts:

    % cat inventory/hosts
    # See Ansible Documentation > Inventory > Hosts and Groups
    # http://docs.ansible.com/ansible/latest/intro_inventory.html#hosts-and-groups
    rack01-node01.example.com
    rack01-node02.example.com
    rack01-node03.example.com
    rack01-node04.example.com
    rack02-node01.example.com
    rack02-node02.example.com
    rack02-node03.example.com
    rack02-node04.example.com

A sample Ansible playbook is provided at `prereq-check.yml`:

    ---
    - hosts: all
      strategy: free
      gather_facts: no
      become: yes
      become_user: root

      vars:
        outputdir: out

      roles:
        - prereq-checks

Change the output directory by setting `outputdir`. Otherwise, it defaults to
the current directory.

Running the above playbook will store output files under `./out/`. For example:

    % ansible-playbook prereq-check.yml
    % ls ./out
    rack01-node01.example.com.out	rack02-node01.example.com.out
    rack01-node02.example.com.out	rack02-node02.example.com.out
    rack01-node03.example.com.out	rack02-node03.example.com.out
    rack01-node04.example.com.out	rack02-node04.example.com.out
