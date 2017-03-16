using System.IO;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Logging;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
    public class ExportOrderToErpSystemTask : IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder> 
    {
        public PipelineExecutionResult Execute(PurchaseOrder subject)
        {
            var orderInformation = string.Format("{0}: {1} customer {2} \r\n",
                subject.OrderNumber,
                new UCommerce.Money(subject.OrderTotal.GetValueOrDefault(), subject.BillingCurrency),
                subject.Customer.EmailAddress);

            File.AppendAllText("C:\\ERP\\ERP.txt", orderInformation);
          
            return PipelineExecutionResult.Success;
        }
    }
}
