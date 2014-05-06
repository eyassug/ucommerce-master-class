using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Infrastructure;
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
			bool supports = dataType.DefinitionName ==
			               GetType().Name.Replace("ControlFactory", "");	
			return supports;
		}

		public Control GetControl(IProperty property)
		{
			var dropDownList = new SafeDropDownList();
			var priceGroups = _priceGroupRepository.Select().ToList();

			dropDownList.Items.Add(new ListItem() { Text = "(auto)", Value = "0"});

			foreach (var priceGroup in priceGroups)
			{
				dropDownList.Items.Add(
					new ListItem() 
					{ 
						Text = priceGroup.Name, 
						Value = priceGroup.PriceGroupId.ToString(),
						Selected = priceGroup.PriceGroupId.ToString() == property.GetValue().ToString()
					});
			}

			return dropDownList;
		}

		public bool Adapts(Control control)
		{
			return control.GetType() == typeof(SafeDropDownList);
		}

		public object GetValue(Control control)
		{
			var safeDropDownList = control as SafeDropDownList;

			if (safeDropDownList != null)
			{
				return safeDropDownList.SelectedValue;
			}

			throw new Exception();
		}
	}
}
