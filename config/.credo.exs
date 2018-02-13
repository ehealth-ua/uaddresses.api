%{
  configs: [
    %{
      color: true,
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: ["lib/uaddresses_api/tasks.ex"]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Readability.ModuleDoc, exit_status: 0},
        {Credo.Check.Refactor.CyclomaticComplexity, exit_status: 0},
      ]
    }
  ]
}
