using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
	public class ExportOrderToErpSystemTask : IPipelineTask<PurchaseOrder>
	{
		private readonly string _connectionString;
		private readonly string _myProperty;

		public string myProperty { get; set; }

		public ExportOrderToErpSystemTask(string connectionString, string myProperty)
		{
			_connectionString = connectionString;
			_myProperty = myProperty;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			var orderNumber = subject.OrderNumber;
			var customerEmail = subject.Customer.EmailAddress;
			var currency = subject.BillingCurrency.ISOCode;
			var orderTotal = subject.OrderTotal;

			string content = string.Format("{0}: {1}{2} customer: {3} \r\n", orderNumber, orderTotal, currency, customerEmail);

			File.AppendAllText(_connectionString, content);
		
			return PipelineExecutionResult.Success;
		}
	}
}
