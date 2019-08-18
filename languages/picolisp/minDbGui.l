# vim:ft=lisp:et:ts=3:sw=3
# license (c) Software Lab. Alexander Burger
# SUMMARY: A Minimal PicoLisp DB/GUI Application
# USAGE:
#   $ pil minDbGui.l -main -go -wait
#   $ pil minDbGui.l -main -go +
# DEPS: $ paci picolisp
# REF:
#   EN: http://picolisp.com/wiki/?minDbGui
#   RU: https://habrahabr.ru/post/247965/
#

(allowed ()
   "!work" "@lib.css" )

(load "@lib/http.l" "@lib/xhtml.l" "@lib/form.l")

(class +Prs +Entity)
(rel nm (+Sn +IdxFold +String))        # Name
(rel adr (+IdxFold +String))           # Address
(rel em (+String))                     # E-Mail
(rel tel (+String))                    # Telephone
(rel dob (+Date))                      # Date of birth

(de work ()
   (app)
   (action
      (html 0 Ttl "@lib.css" NIL
         (<ping> 2)
         (ifn *Login
            (form NIL
               (gui 'pw '(+PwField) 20 ,"Password")
               (gui '(+Button) ,"login"
                  '(ifn (= "mypass" (val> (: home pw)))
                     (error ,"Permission denied")
                     (on *Login)
                     (url "!work") ) ) )
            (form NIL
               (<grid> "--."
                  "Name" (gui 'nm '(+DbHint +TextField) '(nm +Prs) 20)
                  (searchButton '(init> (: home query)))
                  "Address" (gui 'adr '(+DbHint +TextField) '(adr +Prs) 20)
                  (resetButton '(nm adr query)) )
               (gui 'query '(+QueryChart) 12
                  '(goal
                     (quote
                        @Nm (val> (: home nm))
                        @Adr (val> (: home adr))
                        (select (@@)
                           ((nm +Prs @Nm) (adr +Prs @Adr))
                           (tolr @Nm @@ nm)
                           (part @Adr @@ adr) ) ) )
                  6
                  '((This) (list (: nm) (: adr) (: em) (: tel) (: dob)))
                  '((L D)
                     (cond
                        (D
                           (mapc
                              '((K V) (put!> D K V))
                              '(nm adr em tel dob)
                              L )
                           D )
                        ((car L)
                           (new! '(+Prs) 'nm (car L)) ) ) ) )
               (<table> NIL (choTtl "Entries" '+Prs)
                  (quote
                     (NIL "Name")
                     (NIL "Address")
                     (NIL "E-Mail")
                     (NIL "Telephone")
                     (NIL "Date of birth") )
                  (do 12
                     (<row> NIL
                        (gui 1 '(+TextField) 30)
                        (gui 2 '(+TextField) 40)
                        (gui 3 '(+MailField) 20)
                        (gui 4 '(+TelField) 15)
                        (gui 5 '(+DateField) 10)
                        (gui 6 '(+DelRowButton)
                           '(lose!> (curr))
                           '(text "Delete Entry @1?" (curr 'nm)) ) ) ) )
               (scroll 12) ) ) ) ) )

(de main ()
   (locale "UK")
   (pool "adr.db") )

(de go ()
   (server 8080 "!work") )
