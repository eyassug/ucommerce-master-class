using System;
using System.Linq;
using FluentNHibernate.Utils;
using NHibernate.Type;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using NHibernate.Linq;
using UCommerce.Security;

namespace MyUCommerceApp.Test
{

	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING = @"Data Source=.\SQLExpress;database=MasterClass;user id=sa;password=SQLExpress2012";

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var order = session.Query<PurchaseOrder>().First();
			}
		}

		[Test]
		public void ProductsByOrderLine()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query =
					from orderLine in session.Query<OrderLine>()
					join product in session.Query<Product>()
						on new {orderLine.Sku, orderLine.VariantSku}
							equals
						new {product.Sku, product.VariantSku}
					select new { orderLine, product};
			}
		}

		[Test]
		public void PreFetchUsingLinq()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var orders = session.Query<PurchaseOrder>()
					.Fetch(x => x.BillingAddress)
					.Where(x => x.BillingAddress != null)
					.ToList();

				foreach (var purchaseOrder in orders)
				{
					var firstName = purchaseOrder.BillingAddress.FirstName;
				}
			}
		}

		[Test]
		public void NPlusOneProblem()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var orders = session.Query<PurchaseOrder>().Where(x => x.BillingAddress != null).ToList();
				foreach (var purchaseOrder in orders)
				{
					var firstName = purchaseOrder.BillingAddress.FirstName;
				}
			}
		}

		[Test]
		public void ProductByProperties()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.Query<Product>().Where(x => x.ProductProperties
						.Any(y => y.ProductDefinitionField.Name == "ShowOnHomepage" && y.Value == "True"));
				
				var result = query.ToList();
			}
		}

		[Test]
		public void Hql()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.CreateQuery(
				@"
					select p from Product p
				").Future<Product>();

				var result = query.ToList();

			}
		}

		[Test]
		public void FetchWithHql()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = GetSessionProvider().GetSession())
			{
				var query = session.CreateQuery(
				@"
					select p from Product p
					left join fetch p.Variants
				").Future<Product>();

				var result = query.ToList();
			}
		}


		private SessionProvider GetSessionProvider()
		{
			var commerceConfigProviderStub = MockRepository.GenerateStub<CommerceConfigurationProvider>();
			commerceConfigProviderStub
				.Stub(x => x.GetRuntimeConfiguration())
				.Return(new RuntimeConfigurationSection
				{
					EnableCache = true,
					CacheProvider = "NHibernate.Caches.SysCache2.SysCacheProvider, NHibernate.Caches.SysCache2",
					ConnectionString = CONNECTIONSTRING
				});

			var userServiceStub = MockRepository.GenerateStub<IUserService>();
			userServiceStub.Stub(x => x.GetCurrentUser()).Return(new User("system"));
			userServiceStub.Stub(x => x.GetCurrentUserName()).Return("system");

			var sessionProvider = new SessionProvider(commerceConfigProviderStub, userServiceStub);

			return sessionProvider;
		}
	}
}