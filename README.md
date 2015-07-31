# pivotal2trello
Move items from [Pivotal Tracker](https://www.pivotaltracker.com/) to a [Trello](https://trello.com/) board

## Requirements
* Perl v5.16 or higher.
* Install [cpanminus](http://cpanmin.us/) if you don't already have it.

```
cpanm Text::CSV  
cpanm Email::MIME   
cpanm Email::Sender::Simple
```

## Steps
1. Login to Trello, choose one of your Boards.
2. Click *Show Menu* on the right-hand side.
3. Click *More*.
4. Choose *Email-to-board Settings*.
5. Copy the email address for the board, and alter the script to use this.
6. Adjust settings for *Your emailed cards appear in*.
7. Close that, choose *Labels*.
8. Create labels to match any Pivotal labels you might have used (from Pivotal labels, " - " gets replaced with "-", and spaces are replaced with underscores).
9. Run the script.

## Notes
Pivotal will not export any files attached to items.

## TODO
* Handle the *Type* column.
