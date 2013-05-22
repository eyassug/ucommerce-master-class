using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Pipelines;

namespace MyUCommerceApp.Pipelines
{
	public class FreeProductsForThePeopleTask : IPipelineTask<PurchaseOrder>
	{
		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			subject.OrderTotal = 0;
			return PipelineExecutionResult.Success;
		}
	}
}
