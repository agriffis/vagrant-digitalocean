require "vagrant-digitalocean/actions/destroy"
require "vagrant-digitalocean/actions/read_state"
require "vagrant-digitalocean/actions/setup_provisioner"
require "vagrant-digitalocean/actions/setup_nfs"
require "vagrant-digitalocean/actions/setup_user"
require "vagrant-digitalocean/actions/up"

module VagrantPlugins
  module DigitalOcean
    class ActionDispatch
      # Include the built-in callable actions, eg SSHExec
      include Vagrant::Action::Builtin

      def action(name)
        send(name)
      end

      def up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate

          # build the vm if necessary
          builder.use Actions::Up

          # setup vagrant user
          builder.use Actions::SetupUser

          # execute provisioners
          builder.use Provision

          # setup provisioners, comes after Provision to force nfs folders
          builder.use Actions::SetupProvisioner

          # set the host and remote ips for NFS
          builder.use Actions::SetupNFS

          # mount the nfs folders which should be all shared folders
          builder.use NFS
        end
      end

      def ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use SSHExec
        end
      end

      def read_state
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::ReadState
        end
      end

      def destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::Destroy
        end
      end
    end
  end
end