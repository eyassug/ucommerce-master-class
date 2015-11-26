using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.BusinessLogic.SiteContext
{
    public class MyCatalogContext : CatalogContext
    {
        private readonly IMemberService _memberService;

        public MyCatalogContext(IDomainService domainService, IRepository<ProductCatalogGroup> productCatalogGroupRepository, IRepository<ProductCatalog> productCatalogRepository, IRepository<PriceGroup> priceGroupRepository, IMemberService memberService) 
            : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
        {
            _memberService = memberService;
        }

        public override string CurrentCatalogName
        {
            get
            {
                if (_memberService.IsLoggedIn() || HttpContext.Current.Request.QueryString["loggedin"] != null)
                    return "Private Catalog";

                return base.CurrentCatalogName;
            }
            set { base.CurrentCatalogName = value; }
        }
    }
}