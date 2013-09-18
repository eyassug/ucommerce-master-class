using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.ControlFactories
{
	public class PriceGroupControlFactory : IControlFactory
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public PriceGroupControlFactory(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public bool Supports(DataType dataType)
		{
			return dataType.DefinitionName == "PriceGroup";
		}

		public Control GetControl(IProperty property)
		{
			var priceGroupDropDownList = new SafeDropDownList();
			priceGroupDropDownList.Items.Add(
				new ListItem { Text = "(auto)", Value = "0"});

			var priceGroups = _priceGroupRepository.Select().ToList();

			var priceGroupItems = priceGroups.Select(x => new ListItem
			{
				Text = string.Format("{0} ({1})", x.Name, x.VATRate),
				Value = x.PriceGroupId.ToString(),
				Selected = x.PriceGroupId.ToString() == property.GetValue().ToString()
			});

			priceGroupDropDownList.Items.AddRange(priceGroupItems.ToArray());

			return priceGroupDropDownList;
		}
	}
}
