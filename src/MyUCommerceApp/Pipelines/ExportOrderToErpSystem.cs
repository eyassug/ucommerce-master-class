using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
	public class ExportOrderToErpSystem : IPipelineTask<PurchaseOrder>
	{
		private readonly string _connectionString;

		public ExportOrderToErpSystem(string connectionString)
		{
			_connectionString = connectionString;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			var orderNumber = subject.OrderNumber;
			var customerEmail = subject.Customer.EmailAddress;
			var currency = subject.BillingCurrency.ISOCode;
			var orderTotal = subject.OrderTotal;

			var content = string.Format("{0}: {1}{2} customer: {3} \r\n", orderNumber, orderTotal, currency, customerEmail);

			File.AppendAllText(_connectionString, content);

			return PipelineExecutionResult.Success;
		}
	}
}
