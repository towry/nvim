;; extends

((import_statement
  (import_clause) @name (#set! @name "text" "IMPORTS"))+
  (#set! "kind" "Module")
 ) @symbol

((
  (decorator
    (call_expression
      function: (identifier) @decorator
      ))
  (public_field_definition
    name: (property_identifier) @name
    type: (type_annotation))+)
 (#eq? @decorator "Prop")
 (#set! "kind" "Field")
 (#gsub! @name "^(.+)$" "@Prop: %1")
) @symbol

;; match property 
(public_field_definition
  name: (property_identifier) @name
  value: (_) @value
  (#set! "kind" "Field")
) @symbol

