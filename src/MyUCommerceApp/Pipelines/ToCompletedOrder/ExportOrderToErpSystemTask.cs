using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines.ToCompletedOrder
{
    public class ExportOrderToErpSystemTask : IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder>
    {
        public ExportOrderToErpSystemTask()
        {

        }

        public PipelineExecutionResult Execute(PurchaseOrder subject)
        {
            var orderInformation = string.Format("orderNumber: {0} orderTotal: {1} number of orderlines: {2} customer email: {3}",
                subject.OrderNumber, 
                new UCommerce.Money(subject.OrderTotal.GetValueOrDefault(), subject.BillingCurrency),
                subject.OrderLines.Count,
                subject.Customer.EmailAddress
            );

            System.IO.File.AppendAllText("C:\\ERP\\ERP.TXT", orderInformation);

            return PipelineExecutionResult.Success;
        }
    }
}
