using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyUCommerceApp.Library.Context;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.Content;
using UCommerce.Security;

namespace MyUCommerceApp.Test
{
	[TestFixture]
	public class MyCatalogContextTests
	{
		[Test]
		public void Logged_In_Member_Gets_A_Different_Catalog()
		{
			// Arrange
			var domainServiceStub = MockRepository
				.GenerateStub<IDomainService>();
			domainServiceStub
				.Stub(x => x.GetDomains())
				.Return(new List<Domain>());

			var memberServiceStub = MockRepository
				.GenerateStub<IMemberService>();

			memberServiceStub
				.Stub(x => x.IsLoggedIn())
				.Return(true);

			var myCatalogContext = new MyCatalogContext(
				domainServiceStub, memberServiceStub);

			// Act
			string catalogName = myCatalogContext
				.CurrentCatalogName;

			// Assert
			Assert.That(catalogName, Is.EqualTo("Private"));
		}
	}
}
