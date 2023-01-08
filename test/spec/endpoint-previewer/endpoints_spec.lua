describe("endpoint-previewer.endpoints", function()
  local module = require("endpoint-previewer.endpoints")

  describe("is loaded", function()
    it("is not loaded", function()
      assert.is_false(module.is_loaded())
    end)

    it("is loaded", function()
      module.parse_file("test/fixtures/endpoints.json")
      assert.is_true(module.is_loaded())
    end)
  end)

  describe("apis order", function()
    it("has ordered api names", function()
      module.parse('{"apis":{"second":{},"first":{}}}')
      local result = module.get_api_names()
      assert.is_not_nil(result)
      assert.equals(2, #result)
      assert.is_same({"first", "second"}, result)
    end)
  end)

  describe("invalid api", function()
    it("has errors", function()
      local result = module.get_by_api_name("invalid api")
      assert.is_nil(result)
    end)
  end)

  describe("selects the correct file or url to load", function()
    after_each(function()
       package.loaded["endpoint-previewer.config"] = nil
    end)

    it("prefers endpoints_file if configured", function()
      local conf = require("endpoint-previewer.config")
      conf.setup({
        endpoints_file = "test/fixtures/endpoints.json"
      })
      module.load()
      assert.is_true(module.is_loaded())
    end)
  end)

  describe("endpoint defaults", function()
    it("replaces an array of an replacement", function()
      local result = module.replace_with_defaults({url="/matches.{format}"},{format={"json","xml"}})
      assert.equals(2, #result)
    end)

    it("replaces multiple replacements in one url", function()
      local result = module.replace_with_defaults({url="/{lang}/matches.{format}"}, {lang={"en"},format={"json","xml"}})
      assert.equals(2, #result)
      assert.is_same({{url="/en/matches.json", replaced={lang="en",format="json"}}, {url="/en/matches.xml",replaced={lang="en",format="xml"}}}, result)
    end)
  end)

  describe("global", function()
    it("has five endpoints", function()
      module.parse_file("test/fixtures/endpoints.json")
      local result = module.get_by_api_name("")
      assert.is_not_nil(result)
      assert.equals(5, #result)
      assert.equals("/de/notches.json", result[1].url)
      assert.is_same({lang = "de"}, result[1].replaced)
      assert.equals("/{lang}/notches.json", result[1].original_url)
      assert.equals("/en/endpoint.json", result[2].url)
      assert.equals("/en/endpoint.xml",result[3].url)
      assert.is_same({lang = "en", format = "xml"}, result[3].replaced)
      assert.equals("/en/match/{matchId}.json", result[4].url)
      assert.is_same({"matchId"}, result[4].placeholders)
      assert.equals("/en/matches.json", result[5].url)
    end)
  end)

  describe("pet api v1", function()
    module.parse_file("test/fixtures/endpoints.json")

    it("has seven endpoints", function()
      local result = module.get_by_api_name("pet api v1")
      assert.is_not_nil(result)
      assert.equals(9, #result)
      assert.equals("", result[1].api)
      assert.equals("/pets/v1/cat/{catId}.json", result[6].url)
      assert.equals("pet api v1", result[6].api)
    end)

    it("has two api endpoints", function()
      local result = module.get_by_api_name("pet api v1", {noglobal=true})
      assert.is_not_nil(result)
      assert.equals(4, #result)
      assert.equals("pet api v1", result[1].api)
      assert.equals("/pets/v1/cat/{catId}.json", result[1].url)
      assert.is_same({catId = "^cat:\\d+$"}, result[1].requirements)
      assert.equals("/pets/v1/cats.json", result[2].url)
      assert.equals("/pets/v1/cats.xml", result[3].url)
      assert.equals("/pets/v1/pets.json", result[4].url)
    end)

    it("has one endpoint matching cat:1 urn", function()
      local result = module.get_endpoint_by_api_name_and_urn("pet api v1", "cat:1")
      assert.is_not_nil(result)
      assert.equals(1, #result)
      assert.equals("/pets/v1/cat/cat:1.json", result[1].url)
      assert.equals("catId", result[1].matches_placeholder)
      assert.is_same({}, result[1].placeholders)
    end)

  end)
end)
