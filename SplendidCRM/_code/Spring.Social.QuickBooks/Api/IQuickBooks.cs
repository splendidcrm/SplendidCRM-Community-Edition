/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.Data;
using Spring.Rest.Client;
using System.Collections.Generic;

namespace Spring.Social.QuickBooks.Api
{
	public class IAccountOperations
	{
		public IList<Account> GetAll(string filter, string sort)
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   GetById  (string id  )
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   GetByName(string name)
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   Update   (DataRow row)
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   Delete   (string id  )
		{
			throw(new Exception("Not implemented"));
		}
	}

	public class ICustomerOperations
	{
		public IList<Customer> GetAll(string filter, string sort)
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   GetById  (string id  )
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   GetByName(string name)
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   Update   (DataRow row)
		{
			throw(new Exception("Not implemented"));
		}
		public DataRow   Delete   (string id  )
		{
			throw(new Exception("Not implemented"));
		}
	}

	public interface IQuickBooks : IApiBinding
	{
		IAccountOperations    AccountOperations    { get; }
		ICustomerOperations   CustomerOperations   { get; }
		/*
		IEstimateOperations   EstimateOperations   { get; }
		IInvoiceOperations    InvoiceOperations    { get; }
		ISalesOrderOperations SalesOrderOperations { get; }
		IPaymentOperations    PaymentOperations    { get; }
		IItemOperations       ItemOperations       { get; }
		IShipMethodOperations ShipMethodOperations { get; }
		ITaxRateOperations    TaxRateOperations    { get; }
		IRestOperations       RestOperations       { get; }
		*/
	}
}
