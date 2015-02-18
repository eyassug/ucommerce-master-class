using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MyUCommerceApp.BusinessLogic.Integration;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.BusinessLogic.Pipelines.Checkout
{
	public class ExportOrderToErpSystem : IPipelineTask<PurchaseOrder>
	{
		private readonly IErpConnector _erpConnector;

		public ExportOrderToErpSystem(IErpConnector erpConnector)
		{
			_erpConnector = erpConnector;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			_erpConnector.ExportOrderToErp(subject.OrderNumber);
			
			return PipelineExecutionResult.Success;
		}
	}
}
