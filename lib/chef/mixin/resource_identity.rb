#
# Author:: Adam Edwards (<adamed@chef.io>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  module Mixin
    module ResourceIdentity

      def validate_identity(specified_user, password = nil, specified_domain = nil)
        validate_identity_platform(specified_user, password, specified_domain)
        validate_identity_syntax(specified_user, password, specified_domain)
      end

      def validate_identity_platform(specified_user, password = nil, specified_domain = nil)
        if ! Chef::Platform.windows?
          if ! password.nil? || ! specified_domain.nil?
            raise Exceptions::UnsupportedPlatform, "The `domain` and `password` properties are only supported on the Windows platform"
          end
        else
          if ! specified_user.nil? && password.nil?
            raise ArgumentError, "A `password` property must be specified when the `user` property is specified on the Windows platform"
          end
        end
      end

      def validate_identity_syntax(specified_user, password = nil, specified_domain = nil)
        domain, user = qualify_identity(specified_user, specified_domain)

        if ( ! password.nil? || ! domain.nil? ) && user.nil?
          raise ArgumentError, "The `password` or `domain` property was specified without specification of the `user` property"
        end
      end

      def qualify_identity(specified_user, specified_domain = nil)
        domain = specified_domain
        user = specified_user

        if specified_user.nil? && ! specified_domain.nil?
          raise ArgumentError, "The domain `#{specified_domain}` was specified, but no user name was given"
        end

        if ! specified_user.nil? && specified_domain.nil?
          domain_and_user = user.split('\\')

          if domain_and_user.length == 1
            domain_and_user = user.split('@')
          end

          if domain_and_user.length == 2
            domain = domain_and_user[0]
            user = domain_and_user[1]
          elsif domain_and_user.length != 1
            raise ArgumentError, "The specified user name `#{user}` is not a syntactically valid user name"
          end
        end

        [domain, user]
      end

      protected(:validate_identity)
      protected(:validate_identity_platform)
      protected(:validate_identity_syntax)
      protected(:qualify_identity)

    end
  end
end
