using System;
using System.Collections.Generic;

namespace Spring.Social.LinkedIn.Api.Impl
{
    /// <summary>
    /// Represents a LinkedIn invitation.
    /// </summary>
    /// <author>Bruno Baia</author>
    class Invitation
    {
        public string Subject { get; private set; }

        public string Body { get; private set; }

        public InvitationRecipient Recipient { get; private set; }

        public Invitation(string subject, string body, InvitationRecipient recipient)
        {
            this.Subject = subject;
            this.Body = body;
            this.Recipient = recipient;
        }
    }

    /// <summary>
    /// Represents LinkedIn invitation recipient.
    /// </summary>
    /// <author>Bruno Baia</author>
    class InvitationRecipient
    {
        public string ID { get; private set; }

        public string AuthToken { get; private set; }

        public string Email { get; private set; }

        public string FirstName { get; private set; }

        public string LastName { get; private set; }

        public InvitationRecipient(string id, string authToken)
        {
            this.ID = id;
            this.AuthToken = authToken;
        }

        public InvitationRecipient(string email, string firstName, string lastName)
        {
            this.Email = email;
            this.FirstName = firstName;
            this.LastName = lastName;
        }
    }
}
