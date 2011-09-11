module Arturaz
  module CustomSerialize
    module ClassMethods
      # Serialize attributes in custom way instead of using default #serialize
      # which always serializes to YAML. This method allows you to serialize
      # in your own kind of ways.
      #
      # For example if you want serialize +Array+ to comma separated string
      # you can use:
      #
      # <pre>
      # custom_serialize :alliance_planet_player_ids, :alliance_ship_player_ids,
      #   :serialize => Proc.new { |value|
      #     value.blank? ? nil : value.join(",")
      #   },
      #   :unserialize => Proc.new { |value|
      #     value.nil? ? [] : value.split(",").map(&:to_i)
      #   }
      # </pre>
      #
      # Where _alliance_planet_player_ids_ and _alliance_ship_player_ids_ are
      # attribute names.
      #
      # Default values for :serialize and :unserialize converts to and from
      # JSON.
      #
      def custom_serialize(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.reverse_merge!(
          :serialize => Proc.new { |value| value.to_json },
          :unserialize => Proc.new { |value| JSON.parse(value) }
        )
        attributes = args

        after_find :custom_unserialize_attributes
        define_method(:custom_unserialize_attributes) do
          attributes.each do |attribute|
            send(:"#{attribute}=", options[:unserialize].call(send(attribute)))
            changed_attributes.delete attribute.to_s
          end

          super() if defined?(super)
        end

        define_method(:custom_serialize_attributes) do
          attributes.each do |attribute|
            send(:"#{attribute}=", options[:serialize].call(send(attribute)))
          end

          true
        end

        before_save :custom_serialize_attributes
        # Restore attributes changed by #custom_serialize_attributes
        after_save :custom_unserialize_attributes
      end
    end
  end
end