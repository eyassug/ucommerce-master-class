using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Logging;
using UCommerce.Pipelines;
namespace MyUCommerceApp.BusinessLogic.Pipelines.ToCompleted
{
    public class ExportOrderToErpTask : UCommerce.Pipelines.IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder>
    {
        private readonly string _connectionString;
        private readonly ILoggingService _loggingService;

        public string AnotherProperty { get; set; }    

        public ExportOrderToErpTask(string connectionString, ILoggingService loggingService)
        {
            _connectionString = connectionString;
            _loggingService = loggingService;
        }

        public PipelineExecutionResult Execute(UCommerce.EntitiesV2.PurchaseOrder subject)
        {
            string orderData = string.Format("order for: {0} {1}: {2} email: {3} \r\n", 
                subject.ProductCatalogGroup.Name, 
                subject.OrderNumber, 
                new Money(subject.OrderTotal.GetValueOrDefault(), 
                subject.BillingCurrency), 
                subject.Customer.EmailAddress);

            File.AppendAllText(_connectionString, orderData);

            return PipelineExecutionResult.Success;
        }
    }
}
