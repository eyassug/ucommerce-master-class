using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines.ToCompleted
{
    public class ExportOrderToErpSystemTask : UCommerce.Pipelines.IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder>
    {
        public PipelineExecutionResult Execute(PurchaseOrder subject)
        {
            string orderInformation = string.Format("{0}: {1} customer: {2} \r\n", 
                    subject.OrderNumber, 
                    new Money(subject.OrderTotal.GetValueOrDefault(), subject.BillingCurrency),
                    subject.Customer.EmailAddress);

            File.AppendAllText("c:\\ERP\\ERP.txt", orderInformation);

            return PipelineExecutionResult.Success;
        }
    }
}
