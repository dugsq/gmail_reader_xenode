Gmail Reader Xenode
===================

**Gmail Reader Xenode** monitors a specific Gmail account for the first unread message from a pre-defined email address set in the `sender` variable in the Configuration File. Once an email from the specific sender is discovered, the Gmail Reader Xenode then sends a message to its children for each attachment within the read email, where the output message data contains the content of the attachment.

###Configuration File Options:###
* loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
* enabled: determines if the Xenode process is allowed to run. Expects true/false.
* debug: enables extra debug messages in the log file. Expects true/false.
* user_name: defines your gmail username. Expects a string.
* passwd: defines your gmail application access token / password. Expects a string.
* sender: defines the sender of the email to monitor. Expects a string.
* interval: defines the number of seconds to wait before polling the Gmail account for new email. Expects a float.

###Example Configuration File:###
* enabled: false
* loop_delay: 30
* debug: false
* user_name: "jsmith@gmaildotcom"
* passwd: "abcdef123456"
* sender: "jdoe@youremaildomaindotcom"
* interval: 300

###Example Input:###
* The Gmail Reader Xenode does not expect nor handle any input. 

###Example Output:###
* msg.data:  "This string contains the actual content of the email attachment."
 
