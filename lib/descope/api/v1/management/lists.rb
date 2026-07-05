# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls for the deny/allow lists (of IPs and texts)
        module Lists
          include Descope::Api::V1::Management::Common

          def create_list(name: nil, type: nil, description: nil, data: nil)
            # Create a new list with the given name and type.
            body = { name:, type: }
            body[:description] = description unless description.nil?
            body[:data] = data unless data.nil?
            post(LIST_CREATE_PATH, body)
          end

          def update_list(id: nil, name: nil, type: nil, description: nil, data: nil)
            # Update an existing list. IMPORTANT: All parameters are used as overrides to the existing list.
            body = { id:, name:, type: }
            body[:description] = description unless description.nil?
            body[:data] = data unless data.nil?
            post(LIST_UPDATE_PATH, body)
          end

          def delete_list(id: nil)
            # Delete an existing list. IMPORTANT: This action is irreversible. Use carefully.
            post(LIST_DELETE_PATH, { id: })
          end

          def load_list(id: nil)
            # Load list by id.
            get("#{LIST_LOAD_PATH}/#{id}")
          end

          def load_list_by_name(name: nil)
            # Load list by name.
            get("#{LIST_LOAD_BY_NAME_PATH}/#{name}")
          end

          def load_all_lists
            # Load all lists.
            get(LIST_LOAD_ALL_PATH)
          end

          def import_lists(lists: nil)
            # Import the given lists.
            post(LIST_IMPORT_PATH, { lists: })
          end

          def list_add_ips(id: nil, ips: nil)
            # Add the given IPs to the list with the given id.
            post(LIST_ADD_IPS_PATH, { id:, ips: })
          end

          def list_remove_ips(id: nil, ips: nil)
            # Remove the given IPs from the list with the given id.
            post(LIST_REMOVE_IPS_PATH, { id:, ips: })
          end

          def list_check_ip(id: nil, ip: nil)
            # Check whether the given IP exists in the list with the given id.
            post(LIST_CHECK_IP_PATH, { id:, ip: })
          end

          def list_add_texts(id: nil, texts: nil)
            # Add the given texts to the list with the given id.
            post(LIST_ADD_TEXTS_PATH, { id:, texts: })
          end

          def list_remove_texts(id: nil, texts: nil)
            # Remove the given texts from the list with the given id.
            post(LIST_REMOVE_TEXTS_PATH, { id:, texts: })
          end

          def list_check_text(id: nil, text: nil)
            # Check whether the given text exists in the list with the given id.
            post(LIST_CHECK_TEXT_PATH, { id:, text: })
          end

          def clear_list(id: nil)
            # Clear all entries from the list with the given id.
            post(LIST_CLEAR_PATH, { id: })
          end
        end
      end
    end
  end
end
