using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.BusinessLogic.Datatypes
{
    public class PriceGroupControlFactory : IControlFactory
    {
        public bool Supports(DataType dataType)
        {
            return dataType.DefinitionName == "PriceGroup";
        }

        public Control GetControl(IProperty property)
        {
            var dropDownlist = new SafeDropDownList();

            var priceGroups = PriceGroup.All().ToList();

            foreach (var priceGroup in priceGroups)
            {
                var listItem = new ListItem(priceGroup.Name, priceGroup.PriceGroupId.ToString());
                listItem.Selected = property.GetValue().ToString() == priceGroup.PriceGroupId.ToString();
                dropDownlist.Items.Add(listItem);
            }

            return dropDownlist;
        }
    }
}
