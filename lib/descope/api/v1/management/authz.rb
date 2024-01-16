# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Authz
          def authz_save_schema(schema: nil, upgrade: false)
            #  Create or update the ReBAC schema.
            #  In case of update, will update only given namespaces and will not delete namespaces unless upgrade flag is true.
            #  Args:
            #  schema (dict): the schema dict with format
            #       {
            #           "name": "name-of-schema",
            #           "namespaces": [
            #               {
            #                   "name": "name-of-namespace",
            #                   "relationDefinitions": [
            #                       {
            #                           "name": "name-of-relation-definition",
            #                           "complexDefinition": {
            #                               "nType": "one of child|union|intersect|sub",
            #                               "children": "optional list of node children - same format as complexDefinition",
            #                               "expression": {
            #                                   "neType": "one of self|targetSet|relationLeft|relationRight",
            #                                   "relationDefinition": "name of relation definition for relationLeft and relationRight",
            #                                   "relationDefinitionNamespace": "the namespace for the rd above",
            #                                   "targetRelationDefinition": "relation definition for targetSet and relationLeft/right",
            #                                   "targetRelationDefinitionNamespace": "the namespace for above"
            #                               }
            #                           }
            #                       }
            #                   ]
            #               }
            #           ]
            #       }
            #   Schema name can be used for projects to track versioning.
            #  @see https://docs.descope.com/api/openapi/authz/operation/SaveSchema/
            request_params = { schema: schema, upgrade: upgrade }
            post(AUTHZ_SCHEMA_SAVE, request_params)
          end

          def authz_delete_schema
            # Delete the schema for the project which will also delete all relations.
            post(AUTHZ_SCHEMA_DELETE)
          end

          def authz_load_schema
            # Load the schema for the project.
            post(AUTHZ_SCHEMA_LOAD)
          end

          def authz_save_namespace(namespace: nil, old_name: nil, schema_name: nil)
            # Create or update the given namespace
            # Will not delete relation definitions not mentioned in the namespace.
            request_params = { namespace: namespace }
            request_params[:oldName] = old_name unless old_name.nil?
            request_params[:schemaName] = schema_name unless schema_name.nil?
            post(AUTHZ_NS_SAVE, request_params)
          end

          def authz_delete_namespace(name: nil, schema_name: nil)
            # Delete the given namespace
            request_params = { name: name }
            request_params[:schemaName] = schema_name unless schema_name.nil?
            post(AUTHZ_NS_DELETE, request_params)
          end

          def authz_save_relation_definition(relation_definition: nil, namespace_name: nil, old_name: nil, schema_name: nil)
            # Create or update the given relation definition
            #  Will not delete relation definitions not mentioned in the namespace.
            request_params = {
              relationDefinition: relation_definition,
              namespaceName: namespace_name
            }
            request_params[:old_name] = old_name unless old_name.nil?
            request_params[:schemaName] = schema_name unless schema_name.nil?
            post(AUTHZ_RD_SAVE, request_params)
          end

          def authz_delete_relation_definition(name: nil, namespace: nil, schema_name: nil)
            # Delete the given relation definition
            request_params = { name: name, namespace: namespace }
            request_params[:schemaName] = schema_name unless schema_name.nil?
            post(AUTHZ_RD_DELETE, request_params)
          end

          def authz_create_relations(relations: nil)
            # Create the given relations based on the existing schema
            #  relations (Array[]): the relations to create. Each in the following format:
            #   {
            #       "resource": "id of the resource that has the relation",
            #       "relationDefinition": "the relation definition for the relation",
            #       "namespace": "namespace for the relation definition",
            #       "target": "the target that has the relation - usually users or other resources",
            #       "targetSetResource": "if the target is a group that has another relation",
            #       "targetSetRelationDefinition": "the relation definition for the targetSet group",
            #       "targetSetRelationDefinitionNamespace": "the namespace for the relation definition for the targetSet group",
            #       "query": {
            #           "tenants": ["t1", "t2"],
            #           "roles": ["r1", "r2"],
            #           "text": "full-text-search",
            #           "statuses": ["enabled|disabled|invited"],
            #           "ssoOnly": True|False,
            #           "withTestUser": True|False,
            #           "customAttributes": {
            #               "key": "value",
            #               ...
            #           }
            #       }
            #   }
            #   Each relation should have exactly one of: target, targetSet, query
            #   Regarding query above, it should be specified if the target is a set of users that matches the query - all fields are optional
            post(AUTHZ_RE_CREATE, { relations: relations })
          end

          def authz_delete_relation(relations: nil)
            # Delete the given relations based on the existing schema
            post(AUTHZ_RE_DELETE, { relations: relations })
          end

          def authz_delete_relations_for_resources(resources: nil)
            # Delete all relations for the given resources
            post(AUTHZ_RE_DELETE_RESOURCES, { resources: resources })
          end

          def authz_has_relations?(relation_queries: nil)
            # Queries the given relations to see if they exist returning true if they do
            post(AUTHZ_RE_HAS_RELATIONS, { relationQueries: relation_queries })
          end

          def authz_who_can_access?(resource: nil, relation_definition: nil, namespace: nil)
            #  Finds the list of targets (usually users) who can access the given resource with the given RD
            request_params = {
              resource: resource,
              relationDefinition: relation_definition,
              namespace: namespace
            }
            post(AUTHZ_RE_WHO, request_params)
          end

          def authz_resource_relations(resources: nil)
            post(AUTHZ_RE_RESOURCE, { resources: resources })
          end

          def authz_target_relations(targets: nil)
            # Returns the list of all defined relations (not recursive) for the given targets.
            post(AUTHZ_RE_TARGETS, { targets: targets })
          end

          def authz_what_can_target_access?(target: nil)
            # Returns the list of all relations for the given target including derived relations from the schema tree.
            res = post(AUTHZ_RE_TARGET_ALL, { target: target })
            raise Descope::AuthException, "could not get relation for target: #{res}" if res['relations'].nil?

            res['relations']
          end
        end
      end
    end
  end
end
