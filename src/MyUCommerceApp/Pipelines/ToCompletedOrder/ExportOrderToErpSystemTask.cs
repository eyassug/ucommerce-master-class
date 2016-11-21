using System.IO;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines.ToCompletedOrder
{
	public class ExportOrderToErpSystemTask : UCommerce.Pipelines.IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder>
	{
		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			string orderInformation = string.Format("{0}: {1} customer: {2}",
				subject.OrderNumber,
				new Money(subject.OrderTotal.GetValueOrDefault(), subject.BillingCurrency),
				subject.Customer.EmailAddress);

			File.AppendAllText("C:\\ERP\\ERP.txt", orderInformation);

			return PipelineExecutionResult.Success;
		}
	}
}
