using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Logging;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines.ToCompleted
{
	public class ExportOrderToErpSystem : UCommerce.Pipelines.IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder>
	{
		private readonly ILoggingService _loggingService;
		private readonly string _connectionString;

		public ExportOrderToErpSystem(ILoggingService loggingService, string connectionString)
		{
			_loggingService = loggingService;
			_connectionString = connectionString;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			var orderNumber = subject.OrderNumber;
			var customerEmail = subject.Customer.EmailAddress;
			var currency = subject.BillingCurrency.ISOCode;
			var orderTotal = subject.OrderTotal;

			string content = string.Format("{0}: {1}{2} customer: {3}", orderNumber, currency, orderTotal, customerEmail);

			File.AppendAllText(_connectionString, content);

			return PipelineExecutionResult.Success;
		}
	}
}
