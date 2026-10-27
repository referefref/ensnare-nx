require 'securerandom'

module Ensnare
  # Adds Ensnare's hidden trap parameters to forms.
  #
  # The original (Rails 3.2) wrapped form_for and form_tag with alias_method_chain.
  # Current Rails builds the hidden tags of every form (form_tag, form_for and form_with)
  # with the private extra_tags_for_form helper, so ensnare-nx prepends this module to
  # ActionView::Base and adds the trap parameters there, directly after the opening <form> tag.
  module FormHelpers
    # Overload form_for to pass in the object name as part of the options hash
    def form_for(record, options = {}, &block)
      options[:html] ||= {}

      case record
      when String, Symbol
        options[:html][:object_name] = record
      else
        object = record.is_a?(Array) ? record.last : record
        options[:html][:object_name] = options[:as] || ActiveModel::Naming.param_key(object)
      end

      super(record, options, &block)
    end

    # form_with: use the scope, or the model's parameter key, as the object name
    def form_with(model: false, scope: nil, url: nil, format: nil, **options, &block)
      object = model.is_a?(Array) ? model.last : model
      object_name = scope || (object ? ActiveModel::Naming.param_key(object) : nil)
      if object_name
        options[:html] = (options[:html] || {}).merge(object_name: object_name)
      end
      super(model: model, scope: scope, url: url, format: format, **options, &block)
    end

    private

    # Called for every form (form_tag, form_for and form_with) before the <form> tag is
    # rendered; its result follows the opening tag.
    def extra_tags_for_form(html_options)
      object_name = html_options.delete("object_name") || html_options.delete(:object_name)
      html_options.delete("honeypot")
      html_options.delete(:honeypot)
      html = super(html_options)
      traps = ensnare_trap_parameters(object_name)
      # Rails returns a plain empty string for GET forms; its own output is safe
      traps.blank? ? html : html.to_s.html_safe + traps
    end

    # Insert hidden parameters (for example "admin" with a value of false).
    # Assuming a real "admin" attribute is not accessible, a changed value
    # shows that the request was tampered with.
    def ensnare_trap_parameters(object_name)
      return nil unless (Ensnare.mode == :enforce || Ensnare.mode == :log)
      trap = (Ensnare.enabled_traps || []).find { |t| t[:type] == :parameter }
      return nil unless trap

      object_name ||= controller_name.tableize.singularize.to_s

      session["ensnare"] ||= {}
      session["ensnare"]["params"] ||= {}
      stored = session["ensnare"]["params"]
      html = ActiveSupport::SafeBuffer.new

      # :admin => hidden parameter named admin with a value of false
      # :debug => hidden parameter named debug with a value of false
      # :random => hidden parameter named random with a random hex value
      # :uid / :gid => parameters that look like UIDs and GIDs
      predefined_parameters = trap.try(:[], :options).try(:[], :predefined_parameters) || []
      predefined_parameters.each do |p|
        k = v = nil
        case p
        when :admin
          k = "admin"
          v = "false"
        when :debug
          k = "debug"
          v = "false"
        when :random
          k = "random"
          v = stored[k] || SecureRandom.hex
        when :gid
          k = "gid"
          v = stored[k] || Random.rand(100000)
        when :uid
          k = "uid"
          v = stored[k] || Random.rand(100000)
        end
        if !k.nil?
          stored[k] = v.to_s
          html << ensnare_hidden_field(object_name, k, v)
        end
      end

      parameter_names = trap.try(:[], :options).try(:[], :parameter_names) || {}
      parameter_names.each do |k, v|
        if v.is_a?(Method) || v.is_a?(Proc)
          v = stored[k.to_s] || v.call
        end
        stored[k.to_s] = v.to_s
        html << ensnare_hidden_field(object_name, k, v)
      end

      html
    end

    def ensnare_hidden_field(object_name, key, value)
      tag(:input, type: "hidden", name: "#{object_name}[#{key}]", value: value.to_s, id: "#{object_name}_#{key}")
    end
  end
end
