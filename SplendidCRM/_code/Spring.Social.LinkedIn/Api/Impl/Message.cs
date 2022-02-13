using System;
using System.Collections.Generic;

namespace Spring.Social.LinkedIn.Api.Impl
{
    /// <summary>
    /// Represents a LinkedIn message.
    /// </summary>
    /// <author>Bruno Baia</author>
    class Message
    {
        public string[] RecipientIds { get; private set; }

        public string Subject { get; private set; }

        public string Body { get; private set; }

        public Message(string subject, string body, string[] recipientIds)
        {
            this.Subject = subject;
            this.Body = body;
            this.RecipientIds = recipientIds;
        }
    }
}
