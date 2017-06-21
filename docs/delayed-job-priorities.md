# Delayed job priorities

We use priorities for delayed jobs. The priorities are from 0 (highest) to 10 (lowest), default is 5.

## Example priorities:

* 0: API calls (fast jobs user is waiting to finnish)
* 1: Image processing (slow jobs user is waiting to finnish)
* 2: Confirmation emails
* 3: User triggered custom CSS compilation
* 4: Search indexing
* 5: Default, Notification emails (new message, new payment etc.)
* 6: Escrow release / money related
* 7: -
* 8: Automatic listing confirmation
* 9: Reminder emails
* 10: Custom CSS reprocessing at deploy

## The rule of thumb

* Every job that keeps user waiting **should have priority less than 5.**
* Every job that has `run_at` defined **should have priority more than 5.**
