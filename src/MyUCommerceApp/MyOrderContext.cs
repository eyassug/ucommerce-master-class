using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Library
{
	public class MyOrderContext : OrderContext
	{
		private readonly IMemberService _memberService;
		private readonly IRepository<PurchaseOrder> _purchaseOrderRepo;

		public MyOrderContext(ICatalogContext catalogContext, IMemberService memberService, IRepository<PurchaseOrder> purchaseOrderRepo) : base(catalogContext)
		{
			_memberService = memberService;
			_purchaseOrderRepo = purchaseOrderRepo;
		}

		public override UCommerce.EntitiesV2.Basket GetBasket()
		{
			var basket = base.GetBasket(false);

			if (basket != null)
				return basket;

			if (_memberService.IsLoggedIn())
			{
				var member = _memberService.GetCurrentMember();
				// return _purchaseOrderRepo.Select().Where(x => x.MemberId == member.MemberId && x.OrderStatus.OrderStatusId == (int)OrderStatus.Basket).SingleOrDefault();
				
			}

			return null;
		}
	}
}
