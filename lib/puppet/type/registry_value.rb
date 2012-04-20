require 'puppet/util/registry_base'
require 'puppet/util/value_path'

Puppet::Type.newtype(:registry_value) do
  include Puppet::Util::RegistryBase

  def self.title_patterns
    [ [ /^(.*?)\Z/m, [ [ :path, lambda{|x| x} ] ] ] ]
  end

  ensurable

  newparam(:path, :parent => Puppet::Util::ValuePath, :namevar => true) do
  end

  newparam(:redirect) do
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:type) do
    newvalues(:string, :array, :dword, :qword, :binary, :expand)
    defaultto :string
  end

  newproperty(:data) do
    desc "The data of the registry value."

    munge do |value|
      case resource[:type]
      when :dword, :qword
        Integer(value)
      when :array
        # REMIND: this is not supported yet
        value
      when :binary
        value
      else #:string, :expand
        value
      end
    end

    defaultto ''
  end

  autorequire(:registry_key) do
    parents = []
    parameter(:path).ascend do |hkey, subkey|
      parents << "#{hkey.keyname}\\#{subkey}"
    end
    parents
  end
end
