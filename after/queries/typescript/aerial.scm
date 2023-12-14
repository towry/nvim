;; extends

((import_statement
  (import_clause) @name (#set! @name "text" "imports"))+
  (#set! "kind" "Module")
 ) @symbol
