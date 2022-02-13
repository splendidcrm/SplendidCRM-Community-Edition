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
using System.Reflection;
using System.Workflow.Activities.Rules;
using System.Collections.Generic;

namespace SplendidCRM
{
	public class RulesParser
	{
		private static ConstructorInfo m_ctorParser               = null;
		private static MethodInfo      m_methParseCondition       = null;
		private static MethodInfo      m_methParseStatementList   = null;
		private static MethodInfo      m_methParseSingleStatement = null;
		private object objParser = null;

		static RulesParser()
		{
			//Assembly asmActivities = Assembly.GetAssembly(typeof(System.Workflow.Activities.Rules.RuleValidation));
			//Type     typParser     = asmActivities.GetType("System.Workflow.Activities.Rules.Parser");
			// 11/29/2010 Paul.  The Parser may not be available in .NET 4.0, so specify the 3.0 version. 
			Type     typParser     = Type.GetType("System.Workflow.Activities.Rules.Parser, System.Workflow.Activities, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35");
			m_ctorParser               = typParser.GetConstructor(BindingFlags.Instance | BindingFlags.NonPublic, null, new Type[] { typeof(System.Workflow.Activities.Rules.RuleValidation) }, null);
			m_methParseCondition       = typParser.GetMethod("ParseCondition"      , BindingFlags.Instance | BindingFlags.NonPublic);
			m_methParseStatementList   = typParser.GetMethod("ParseStatementList"  , BindingFlags.Instance | BindingFlags.NonPublic);
			m_methParseSingleStatement = typParser.GetMethod("ParseSingleStatement", BindingFlags.Instance | BindingFlags.NonPublic);
		}

		public RulesParser(RuleValidation validation)
		{
			objParser = m_ctorParser.Invoke(new object[] { validation } );
		}

		public RuleExpressionCondition ParseCondition(string expressionString)
		{
			try
			{
				return m_methParseCondition.Invoke(objParser, new object[] { expressionString } ) as RuleExpressionCondition;
			}
			catch(TargetInvocationException ex)
			{
				// 10/22/2010 Paul.   Instead of displaying "Exception has been thrown by the target of an invocation.", 
				// catch the error and return the more useful inner exception. 
				throw ex.InnerException;
			}
		}

		public List<RuleAction> ParseStatementList(string statementString)
		{
			try
			{
				return m_methParseStatementList.Invoke(objParser, new object[] { statementString } ) as List<RuleAction>;
			}
			catch(TargetInvocationException ex)
			{
				throw ex.InnerException;
			}
		}

		public RuleAction ParseSingleStatement(string statementString)
		{
			try
			{
				return m_methParseSingleStatement.Invoke(objParser, new object[] { statementString } ) as RuleAction;
			}
			catch(TargetInvocationException ex)
			{
				throw ex.InnerException;
			}
		}
	}
}
