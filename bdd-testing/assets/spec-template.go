//go:build ignore
// Template for a Ginkgo BDD spec file. Copy, rename after the subject under test,
// and replace the placeholders. Run with: go test ./...
//
// Conventions:
//   - Black-box package (package <pkg>_test) — exercise the public API only.
//   - One spec file per subject: <subject>_test.go mirrors <subject>.go.
//   - One bootstrap file per package: <pkg>_suite_test.go (see SKILL.md).
package TEMPLATE_test

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("Subject", func() {
	// Declare the subject under test here. Construct it fresh in BeforeEach so
	// every It gets an isolated instance — never share a pointer across specs.
	var subject *Subject

	BeforeEach(func() {
		subject = NewSubject(/* minimal valid construction */)
	})

	// Nest scenarios as Context/When under the Describe. Read top-down as a
	// sentence: "Subject, when <scenario>, <behavior>."
	Context("when <precondition>", func() {
		BeforeEach(func() {
			// Arrange the scenario-specific state here.
		})

		It("<observable behavior>", func() {
			// Act
			result, err := subject.DoThing()

			// Assert — state the expectation from the user's perspective.
			Expect(err).NotTo(HaveOccurred())
			Expect(result).To(Equal("TODO: expected value"))
		})
	})

	// Data-driven variant: many inputs, one behavior shape.
	DescribeTable("<behavior under parameterization>",
		func(input int, expected string) {
			Expect(subject.Format(input)).To(Equal(expected))
		},
		Entry("zero", 0, "none"),
		Entry("one", 1, "single"),
		Entry("many", 42, "many"),
	)
})
