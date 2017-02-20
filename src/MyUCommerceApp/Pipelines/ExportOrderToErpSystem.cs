using System.IO;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
    public class ExportOrderToErpSystem : IPipelineTask<PurchaseOrder>
    {
        public PipelineExecutionResult Execute(PurchaseOrder subject)
        {
            string orderInformation = string.Format("{0}: {1} customer: {2} \r\n",
                subject.OrderNumber,
                new Money(subject.OrderTotal.GetValueOrDefault(), subject.BillingCurrency).ToString(),
                subject.Customer.EmailAddress); 

            File.AppendAllText("C:\\ERP\\ERP.txt", orderInformation);

            return PipelineExecutionResult.Success;
        }
    }
}
