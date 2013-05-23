module SimplestAuth
  module Session
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations
      include ActiveModel::Conversion

      attr_accessor :email, :password

      validates :email, :password, :presence => true

      validate :user_exists_for_credentials, :if => :credentials_supplied?

      def initialize(attributes = {})
        attributes.each {|k,v| send("#{k}=", v) }
      end

      def user_class
        self.class.user_class
      end

      def user
        @user ||= user_class.authenticate(email, password)
      end

      def persisted?
        false
      end

      private

      def user_exists_for_credentials
        errors.add(:base, "#{user_class} not found for supplied credentials") unless user.present?
      end

      def credentials_supplied?
        email.present? && password.present?
      end

    end

    module ClassMethods
      def set_user_class_name(user_class_name)
        @user_class_name = user_class_name
      end

      def user_class_name
        @user_class_name || 'User'
      end

      def user_class
        user_class_name.constantize
      end
    end

  end
end
