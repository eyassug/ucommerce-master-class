using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.DataTypes
{
	public class PriceGroupControlFactory : IControlFactory, IControlAdapter
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public PriceGroupControlFactory(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public bool Supports(DataType dataType)
		{
			return dataType.DefinitionName ==
			       GetType().Name.Replace("ControlFactory", "");
		}

		public Control GetControl(IProperty property)
		{
			var dropDownList = new SafeDropDownList();
			var priceGroups = _priceGroupRepository.Select().ToList();

			dropDownList.Items.Add(new ListItem() { Text = "(auto)", Value = "0" });

			var value = property.GetValue();

			foreach (var priceGroup in priceGroups)
			{
				dropDownList.Items.Add(new ListItem() { Text = priceGroup.Name, Value = priceGroup.PriceGroupId.ToString()});
			}
			
			if (value != null && !string.IsNullOrEmpty(value.ToString()))
				dropDownList.SelectedValue = value.ToString();

			return dropDownList;
		}

		public bool Adapts(Control control)
		{
			if (control.GetType() == typeof (PriceGroupControlFactory))
				return true;

			return false;
		}

		public object GetValue(Control control)
		{
			return (control as SafeDropDownList).SelectedValue;
		}
	}
}
