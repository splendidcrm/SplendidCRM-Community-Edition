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
using System.IO;
using System.Collections.Generic;
#if NET_4_0 || SILVERLIGHT_5
using System.Threading.Tasks;
#else
using Spring.Rest.Client;
using Spring.Http;
#endif

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Interface defining the Twitter operations for working with locations.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface IGeoOperations
    {
#if NET_4_0 || SILVERLIGHT_5
        /// <summary>
        /// Asynchronously retrieves information about a place.
        /// </summary>
        /// <param name="id">The place ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="Place"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<Place> GetPlaceAsync(string id);

        /// <summary>
        /// Asynchronously retrieves up to 20 places matching the given location.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Place>> ReverseGeoCodeAsync(double latitude, double longitude);

        /// <summary>
        /// Asynchronously retrieves up to 20 places matching the given location and criteria
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="granularity">
        /// The minimal granularity of the places to return. If null, the default granularity (neighborhood) is assumed.
        /// </param>
        /// <param name="accuracy">
        /// A radius of accuracy around the given point. If given a number, the value is assumed to be in meters. 
        /// The number may be qualified with "ft" to indicate feet. If null, the default accuracy (0m) is assumed.
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Place>> ReverseGeoCodeAsync(double latitude, double longitude, PlaceType? granularity, string accuracy);

        /// <summary>
        /// Asynchronously searches for up to 20 places matching the given location.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Place>> SearchAsync(double latitude, double longitude);

        /// <summary>
        /// Asynchronously searches for up to 20 places matching the given location and criteria.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="granularity">
        /// The minimal granularity of the places to return. If null, the default granularity (neighborhood) is assumed.
        /// </param>
        /// <param name="accuracy">
        /// A radius of accuracy around the given point. If given a number, the value is assumed to be in meters. 
        /// The number may be qualified with "ft" to indicate feet. If null, the default accuracy (0m) is assumed.
        /// </param>
        /// <param name="query">
        /// A free form text value to help find places by name. If null, no query will be applied to the search.
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Place>> SearchAsync(double latitude, double longitude, PlaceType? granularity, string accuracy, string query);

        /// <summary>
        /// Asynchronously finds places similar to a place described in the parameters.
        /// <para/>
        /// Returns a list of places along with a token that is required for creating a new place.
        /// <para/>
        /// This method must be called before calling createPlace().
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="name">The name that the place is known as.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SimilarPlaces"/> collection, including a token that can be used to create a new place.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SimilarPlaces> FindSimilarPlacesAsync(double latitude, double longitude, string name);

        /// <summary>
        /// Asynchronously finds places similar to a place described in the parameters.
        /// <para/>
        /// Returns a list of places along with a token that is required for creating a new place.
        /// <para/>
        /// This method must be called before calling CreatePlace().
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="name">The name that the place is known as.</param>
        /// <param name="streetAddress">The place's street address. May be null.</param>
        /// <param name="containedWithin">The ID of the place that the place is contained within.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SimilarPlaces"/> collection, including a token that can be used to create a new place.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SimilarPlaces> FindSimilarPlacesAsync(double latitude, double longitude, string name, string streetAddress, string containedWithin);

        /// <summary>
        /// Asynchronously creates a new place.
        /// </summary>
        /// <param name="placePrototype">
        /// The place prototype returned in a <see cref="SimilarPlaces"/> from a call to FindSimilarPlaces().
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="Place"/> object with the newly created place data.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<Place> CreatePlaceAsync(PlacePrototype placePrototype);
#else
#if !SILVERLIGHT
        /// <summary>
        /// Retrieves information about a place.
        /// </summary>
        /// <param name="id">The place ID.</param>
        /// <returns>A <see cref="Place"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Place GetPlace(string id);

        /// <summary>
        /// Retrieves up to 20 places matching the given location.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <returns>
        /// A list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Place> ReverseGeoCode(double latitude, double longitude);

        /// <summary>
        /// Retrieves up to 20 places matching the given location and criteria
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="granularity">
        /// The minimal granularity of the places to return. If null, the default granularity (neighborhood) is assumed.
        /// </param>
        /// <param name="accuracy">
        /// A radius of accuracy around the given point. If given a number, the value is assumed to be in meters. 
        /// The number may be qualified with "ft" to indicate feet. If null, the default accuracy (0m) is assumed.
        /// </param>
        /// <returns>
        /// A list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Place> ReverseGeoCode(double latitude, double longitude, PlaceType? granularity, string accuracy);

        /// <summary>
        /// Searches for up to 20 places matching the given location.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <returns>
        /// A list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Place> Search(double latitude, double longitude);

        /// <summary>
        /// Searches for up to 20 places matching the given location and criteria.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="granularity">
        /// The minimal granularity of the places to return. If null, the default granularity (neighborhood) is assumed.
        /// </param>
        /// <param name="accuracy">
        /// A radius of accuracy around the given point. If given a number, the value is assumed to be in meters. 
        /// The number may be qualified with "ft" to indicate feet. If null, the default accuracy (0m) is assumed.
        /// </param>
        /// <param name="query">
        /// A free form text value to help find places by name. If null, no query will be applied to the search.
        /// </param>
        /// <returns>
        /// A list of <see cref="Place"/>s that the point is within.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Place> Search(double latitude, double longitude, PlaceType? granularity, string accuracy, string query);

        /// <summary>
        /// Finds places similar to a place described in the parameters.
        /// <para/>
        /// Returns a list of places along with a token that is required for creating a new place.
        /// <para/>
        /// This method must be called before calling createPlace().
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="name">The name that the place is known as.</param>
        /// <returns>
        /// A <see cref="SimilarPlaces"/> collection, including a token that can be used to create a new place.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SimilarPlaces FindSimilarPlaces(double latitude, double longitude, string name);

        /// <summary>
        /// Finds places similar to a place described in the parameters.
        /// <para/>
        /// Returns a list of places along with a token that is required for creating a new place.
        /// <para/>
        /// This method must be called before calling CreatePlace().
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="name">The name that the place is known as.</param>
        /// <param name="streetAddress">The place's street address. May be null.</param>
        /// <param name="containedWithin">The ID of the place that the place is contained within.</param>
        /// <returns>
        /// A <see cref="SimilarPlaces"/> collection, including a token that can be used to create a new place.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SimilarPlaces FindSimilarPlaces(double latitude, double longitude, string name, string streetAddress, string containedWithin);

        /// <summary>
        /// Creates a new place.
        /// </summary>
        /// <param name="placePrototype">
        /// The place prototype returned in a <see cref="SimilarPlaces"/> from a call to FindSimilarPlaces().
        /// </param>
        /// <returns>A <see cref="Place"/> object with the newly created place data.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Place CreatePlace(PlacePrototype placePrototype);
#endif

        /// <summary>
        /// Asynchronously retrieves information about a place.
        /// </summary>
        /// <param name="id">The place ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="Place"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetPlaceAsync(string id, Action<RestOperationCompletedEventArgs<Place>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves up to 20 places matching the given location.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Place"/>s that the point is within.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler ReverseGeoCodeAsync(double latitude, double longitude, Action<RestOperationCompletedEventArgs<IList<Place>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves up to 20 places matching the given location and criteria
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="granularity">
        /// The minimal granularity of the places to return. If null, the default granularity (neighborhood) is assumed.
        /// </param>
        /// <param name="accuracy">
        /// A radius of accuracy around the given point. If given a number, the value is assumed to be in meters. 
        /// The number may be qualified with "ft" to indicate feet. If null, the default accuracy (0m) is assumed.
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Place"/>s that the point is within.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler ReverseGeoCodeAsync(double latitude, double longitude, PlaceType? granularity, string accuracy, Action<RestOperationCompletedEventArgs<IList<Place>>> operationCompleted);

        /// <summary>
        /// Asynchronously searches for up to 20 places matching the given location.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Place"/>s that the point is within.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SearchAsync(double latitude, double longitude, Action<RestOperationCompletedEventArgs<IList<Place>>> operationCompleted);

        /// <summary>
        /// Asynchronously searches for up to 20 places matching the given location and criteria.
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="granularity">
        /// The minimal granularity of the places to return. If null, the default granularity (neighborhood) is assumed.
        /// </param>
        /// <param name="accuracy">
        /// A radius of accuracy around the given point. If given a number, the value is assumed to be in meters. 
        /// The number may be qualified with "ft" to indicate feet. If null, the default accuracy (0m) is assumed.
        /// </param>
        /// <param name="query">
        /// A free form text value to help find places by name. If null, no query will be applied to the search.
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Place"/>s that the point is within.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SearchAsync(double latitude, double longitude, PlaceType? granularity, string accuracy, string query, Action<RestOperationCompletedEventArgs<IList<Place>>> operationCompleted);

        /// <summary>
        /// Asynchronously finds places similar to a place described in the parameters.
        /// <para/>
        /// Returns a list of places along with a token that is required for creating a new place.
        /// <para/>
        /// This method must be called before calling createPlace().
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="name">The name that the place is known as.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SimilarPlaces"/> collection, including a token that can be used to create a new place.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler FindSimilarPlacesAsync(double latitude, double longitude, string name, Action<RestOperationCompletedEventArgs<SimilarPlaces>> operationCompleted);

        /// <summary>
        /// Asynchronously finds places similar to a place described in the parameters.
        /// <para/>
        /// Returns a list of places along with a token that is required for creating a new place.
        /// <para/>
        /// This method must be called before calling CreatePlace().
        /// </summary>
        /// <param name="latitude">The latitude.</param>
        /// <param name="longitude">The longitude.</param>
        /// <param name="name">The name that the place is known as.</param>
        /// <param name="streetAddress">The place's street address. May be null.</param>
        /// <param name="containedWithin">The ID of the place that the place is contained within.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SimilarPlaces"/> collection, including a token that can be used to create a new place.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler FindSimilarPlacesAsync(double latitude, double longitude, string name, string streetAddress, string containedWithin, Action<RestOperationCompletedEventArgs<SimilarPlaces>> operationCompleted);

        /// <summary>
        /// Asynchronously creates a new place.
        /// </summary>
        /// <param name="placePrototype">
        /// The place prototype returned in a <see cref="SimilarPlaces"/> from a call to FindSimilarPlaces().
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="Place"/> object with the newly created place data.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler CreatePlaceAsync(PlacePrototype placePrototype, Action<RestOperationCompletedEventArgs<Place>> operationCompleted);
#endif
    }
}
