#region License

/*
 * Copyright 2002-2012 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#endregion

using System;
using System.Collections.Generic;

using Spring.Json;
using Spring.Rest.Client;
using Spring.Social.OAuth2;
using Spring.Http.Converters;
using Spring.Http.Converters.Json;

using Spring.Social.Facebook.Api.Impl.Json;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// This is the central class for interacting with Facebook.
	/// </summary>
	/// <remarks>
	/// <para>
	/// Most (not all) Facebook operations require OAuth authentication. 
	/// To perform such operations, <see cref="FacebookTemplate"/> must be constructed 
	/// with the minimal amount of information required to sign requests to Facebook's API 
	/// with an OAuth <code>Authorization</code> header.
	/// </para>
	/// <para>
	/// There are some operations, such as searching, that do not require OAuth authentication. 
	/// In those cases, you may use a <see cref="FacebookTemplate"/> that is created through 
	/// the default constructor and without any OAuth details.
	/// Attempts to perform secured operations through such an instance, however, 
	/// will result in <see cref="FacebookApiException"/> being thrown.
	/// </para>
	/// </remarks>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public class FacebookTemplate : AbstractOAuth2ApiBinding, IFacebook 
	{
		private static readonly Uri API_URI_BASE = new Uri("https://graph.facebook.com/");
		private const string PROFILE_URL = "{id}/feed";

		private IUserOperations      userOperations     ;
		private IPlacesOperations    placesOperations   ;
		private IFriendOperations    friendOperations   ;
		private IFeedOperations      feedOperations     ;
		private IGroupOperations     groupOperations    ;
		private ICommentOperations   commentOperations  ;
		private ILikeOperations      likeOperations     ;
		private IEventOperations     eventOperations    ;
		private IMediaOperations     mediaOperations    ;
		private IPageOperations      pageOperations     ;
		private IFqlOperations       fqlOperations      ;
		private IQuestionOperations  questionOperations ;
		private IOpenGraphOperations openGraphOperations;

		private string applicationNamespace;

		/// <summary>
		/// Create a new instance of <see cref="FacebookTemplate"/> able to perform unauthenticated operations against Facebook's API.
		/// </summary>
		/// <remarks>
		/// Some operations, such as search, do not require OAuth authentication. 
		/// A FacebookTemplate created with this constructor will support those operations. 
		/// Any operations requiring authentication will throw an <see cref="FacebookApiException"/>.
		/// </remarks>
		public FacebookTemplate() 
			: base()
		{
			this.InitSubApis();
		}

		/// <summary>
		/// Create a new instance of <see cref="FacebookTemplate"/>.
		/// </summary>
		/// <param name="accessToken">An access token acquired through OAuth authentication with Facebook.</param>
		public FacebookTemplate(string accessToken)
			: base(accessToken)
		{
			this.InitSubApis();
		}

		/// <summary>
		/// Create a new instance of <see cref="FacebookTemplate"/>.
		/// </summary>
		/// <param name="accessToken">An access token acquired through OAuth authentication with Facebook.</param>
		/// <param name="applicationNamespace"></param>
		public FacebookTemplate(string accessToken, string applicationNamespace)
			: base(accessToken)
		{
			this.applicationNamespace = applicationNamespace;
			this.InitSubApis();
		}

		#region IFacebook Members
		public IUserOperations UserOperations
		{
			get { return this.userOperations; }
		}
	
		public IPlacesOperations PlacesOperations
		{
			get { return this.placesOperations; }
		}

		public ILikeOperations LikeOperations
		{
			get { return this.likeOperations; }
		}

		public IFriendOperations FriendOperations
		{
			get { return this.friendOperations; }
		}
	
		public IFeedOperations FeedOperations
		{
			get { return this.feedOperations; }
		}
	
		public IGroupOperations GroupOperations
		{
			get { return this.groupOperations; }
		}

		public ICommentOperations CommentOperations
		{
			get { return this.commentOperations; }
		}
	
		public IEventOperations EventOperations
		{
			get { return this.eventOperations; }
		}
	
		public IMediaOperations MediaOperations
		{
			get { return this.mediaOperations; }
		}
	
		public IPageOperations PageOperations
		{
			get { return this.pageOperations; }
		}
	
		public IFqlOperations FqlOperations
		{
			get { return this.fqlOperations; }
		}
	
		public IQuestionOperations QuestionOperations
		{
			get { return this.questionOperations; }
		}

		public IOpenGraphOperations OpenGraphOperations
		{
			get { return this.openGraphOperations; }
		}
	

		/// <summary>
		/// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of Twitter endpoints 
		/// that may not be otherwise covered by the API binding. 
		/// </summary>
		/// <remarks>
		/// The <see cref="IRestOperations"/> object returned is configured to include an OAuth "Authorization" header on all requests.
		/// </remarks>
		public IRestOperations RestOperations
		{
			get { return this.RestTemplate; }
		}
		#endregion

		/// <summary>
		/// Enables customization of the <see cref="RestTemplate"/> used to consume provider API resources.
		/// </summary>
		/// <remarks>
		/// An example use case might be to configure a custom error handler. 
		/// Note that this method is called after the RestTemplate has been configured with the message converters returned from GetMessageConverters().
		/// </remarks>
		/// <param name="restTemplate">The RestTemplate to configure.</param>
		protected override void ConfigureRestTemplate(RestTemplate restTemplate)
		{
			restTemplate.BaseAddress = API_URI_BASE;
			restTemplate.ErrorHandler = new FacebookErrorHandler();
		}

		protected override OAuth2Version GetOAuth2Version()
		{
			return OAuth2Version.Draft10;
		}

		/// <summary>
		/// Returns a list of <see cref="IHttpMessageConverter"/>s to be used by the internal <see cref="RestTemplate"/>.
		/// </summary>
		/// <remarks>
		/// This implementation adds <see cref="SpringJsonHttpMessageConverter"/> and <see cref="ByteArrayHttpMessageConverter"/> to the default list.
		/// </remarks>
		/// <returns>
		/// The list of <see cref="IHttpMessageConverter"/>s to be used by the internal <see cref="RestTemplate"/>.
		/// </returns>
		protected override IList<IHttpMessageConverter> GetMessageConverters()
		{
			IList<IHttpMessageConverter> converters = base.GetMessageConverters();
			converters.Add(new ByteArrayHttpMessageConverter());
			converters.Add(this.GetJsonMessageConverter());
			return converters;
		}

		/// <summary>
		/// Returns a <see cref="SpringJsonHttpMessageConverter"/> to be used by the internal <see cref="RestTemplate"/>.
		/// <para/>
		/// Override to customize the message converter (for example, to set a custom object mapper or supported media types).
		/// </summary>
		/// <returns>The configured <see cref="SpringJsonHttpMessageConverter"/>.</returns>
		protected virtual SpringJsonHttpMessageConverter GetJsonMessageConverter()
		{
			JsonMapper jsonMapper = new JsonMapper();
			jsonMapper.RegisterDeserializer(typeof(Account                        ), new AccountDeserializer                   ());
			jsonMapper.RegisterDeserializer(typeof(List<Account>                  ), new ListDeserializer<Account>             ());
			jsonMapper.RegisterDeserializer(typeof(Album                          ), new AlbumDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<Album>                    ), new ListDeserializer<Album>               ());
			jsonMapper.RegisterDeserializer(typeof(Checkin                        ), new CheckinDeserializer                   ());
			jsonMapper.RegisterDeserializer(typeof(List<Checkin>                  ), new ListDeserializer<Checkin>             ());
			jsonMapper.RegisterDeserializer(typeof(CheckinPost                    ), new CheckinPostDeserializer               ());
			jsonMapper.RegisterDeserializer(typeof(Comment                        ), new CommentDeserializer                   ());
			jsonMapper.RegisterDeserializer(typeof(List<Comment>                  ), new ListDeserializer<Comment>             ());
			jsonMapper.RegisterDeserializer(typeof(EducationEntry                 ), new EducationEntryDeserializer            ());
			jsonMapper.RegisterDeserializer(typeof(List<EducationEntry>           ), new ListDeserializer<EducationEntry>      ());
			jsonMapper.RegisterDeserializer(typeof(Event                          ), new EventDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<Event>                    ), new ListDeserializer<Event>               ());
			jsonMapper.RegisterDeserializer(typeof(EventInvitee                   ), new EventInviteeDeserializer              ());
			jsonMapper.RegisterDeserializer(typeof(List<EventInvitee>             ), new ListDeserializer<EventInvitee>        ());
			jsonMapper.RegisterDeserializer(typeof(FacebookProfile                ), new FacebookProfileDeserializer           ());
			jsonMapper.RegisterDeserializer(typeof(List<FacebookProfile>          ), new ListDeserializer<FacebookProfile>     ());
			jsonMapper.RegisterDeserializer(typeof(FamilyMember                   ), new FamilyMemberDeserializer              ());
			jsonMapper.RegisterDeserializer(typeof(List<FamilyMember>             ), new ListDeserializer<FamilyMember>        ());
			jsonMapper.RegisterDeserializer(typeof(Group                          ), new GroupDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<Group>                    ), new ListDeserializer<Group>               ());
			jsonMapper.RegisterDeserializer(typeof(GroupMemberReference           ), new GroupMemberReferenceDeserializer      ());
			jsonMapper.RegisterDeserializer(typeof(List<GroupMemberReference>     ), new ListDeserializer<GroupMemberReference>());
			jsonMapper.RegisterDeserializer(typeof(GroupMembership                ), new GroupMembershipDeserializer           ());
			jsonMapper.RegisterDeserializer(typeof(List<GroupMembership>          ), new ListDeserializer<GroupMembership>     ());
			jsonMapper.RegisterDeserializer(typeof(Photo.Image                    ), new ImageDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<Photo.Image>              ), new ImageListDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(Invitation                     ), new InvitationDeserializer                ());
			jsonMapper.RegisterDeserializer(typeof(List<Invitation>               ), new ListDeserializer<Invitation>          ());
			jsonMapper.RegisterDeserializer(typeof(LinkPost                       ), new LinkPostDeserializer                  ());
			jsonMapper.RegisterDeserializer(typeof(List<LinkPost>                 ), new ListDeserializer<LinkPost>            ());
			jsonMapper.RegisterDeserializer(typeof(Location                       ), new LocationDeserializer                  ());
			jsonMapper.RegisterDeserializer(typeof(MusicPost                      ), new MusicPostDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(NotePost                       ), new NotePostDeserializer                  ());
			jsonMapper.RegisterDeserializer(typeof(List<NotePost>                 ), new ListDeserializer<NotePost>            ());
			jsonMapper.RegisterDeserializer(typeof(Page                           ), new PageDeserializer                      ());
			jsonMapper.RegisterDeserializer(typeof(List<Page>                     ), new ListDeserializer<Page>                ());
			jsonMapper.RegisterDeserializer(typeof(Photo                          ), new PhotoDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<Photo>                    ), new ListDeserializer<Photo>               ());
			jsonMapper.RegisterDeserializer(typeof(PhotoPost                      ), new PhotoPostDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(Post                           ), new PostDeserializer                      ());
			jsonMapper.RegisterDeserializer(typeof(List<Post>                     ), new ListDeserializer<Post>                ());
			jsonMapper.RegisterDeserializer(typeof(Question                       ), new QuestionDeserializer                  ());
			jsonMapper.RegisterDeserializer(typeof(List<Question>                 ), new ListDeserializer<Question>            ());
			jsonMapper.RegisterDeserializer(typeof(QuestionOption                 ), new QuestionOptionDeserializer            ());
			jsonMapper.RegisterDeserializer(typeof(List<QuestionOption>           ), new ListDeserializer<QuestionOption>      ());
			jsonMapper.RegisterDeserializer(typeof(Reference                      ), new ReferenceDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(List<Reference>                ), new ListDeserializer<Reference>           ());
			jsonMapper.RegisterDeserializer(typeof(StatusPost                     ), new StatusPostDeserializer                ());
			jsonMapper.RegisterDeserializer(typeof(List<StatusPost>               ), new ListDeserializer<StatusPost>          ());
			jsonMapper.RegisterDeserializer(typeof(StoryTag                       ), new StoryTagDeserializer                  ());
			jsonMapper.RegisterDeserializer(typeof(Dictionary<int, List<StoryTag>>), new StoryTagMapDeserializer               ());
			jsonMapper.RegisterDeserializer(typeof(SwfPost                        ), new SwfPostDeserializer                   ());
			jsonMapper.RegisterDeserializer(typeof(Tag                            ), new TagDeserializer                       ());
			jsonMapper.RegisterDeserializer(typeof(List<Tag>                      ), new ListDeserializer<Tag>                 ());
			jsonMapper.RegisterDeserializer(typeof(Video                          ), new VideoDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<Video>                    ), new ListDeserializer<Video>               ());
			jsonMapper.RegisterDeserializer(typeof(VideoPost                      ), new VideoPostDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(WorkEntry                      ), new WorkEntryDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(List<WorkEntry>                ), new ListDeserializer<WorkEntry>           ());
			jsonMapper.RegisterDeserializer(typeof(List<String>                   ), new ListDeserializer<String>              ());
			return new SpringJsonHttpMessageConverter(jsonMapper);
		}

		private void InitSubApis()
		{
			this.userOperations      = new UserTemplate     (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.placesOperations    = new PlacesTemplate   (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.friendOperations    = new FriendTemplate   (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.feedOperations      = new FeedTemplate     (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.groupOperations     = new GroupTemplate    (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.commentOperations   = new CommentTemplate  (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.likeOperations      = new LikeTemplate     (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.eventOperations     = new EventTemplate    (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.mediaOperations     = new MediaTemplate    (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.pageOperations      = new PageTemplate     (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.fqlOperations       = new FqlTemplate      (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.questionOperations  = new QuestionTemplate (this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
			this.openGraphOperations = new OpenGraphTemplate(this.applicationNamespace, this.RestTemplate, this.IsAuthorized);
		}
	}
}