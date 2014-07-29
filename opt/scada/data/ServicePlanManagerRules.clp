
(defrule invalid-consists-number
   ?trip <- (object (is-a TRIP) (planned-consists ?cons&:(numberp ?cons)))
   (test (not (or (eq ?cons 3) (eq ?cons 6))))
 =>
   (printout t (instance-name ?trip) " has invalid planned-consists " ?cons crlf)  
   (assert (change-rejected))
   (assert (invalid-planned-consists (instance-name ?trip)))
)
