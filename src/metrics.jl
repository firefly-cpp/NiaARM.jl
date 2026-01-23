"""
    support(ct::ContingencyTable)
    support(rule::Rule)

Fraction of transactions that satisfy both antecedent and consequent. Returns 0.0 if undefined.
"""
function support(t::ContingencyTable)
    n = t.countall + t.countlhs + t.countrhs + t.countnull
    res = t.countall / n
    return isfinite(res) ? res : 0.0
end

support(r::Rule) = support(r.ct)

"""
    confidence(ct::ContingencyTable)
    confidence(rule::Rule)

Conditional probability of the consequent given the antecedent. Returns 0.0 if undefined.
"""
function confidence(t::ContingencyTable)
    count_x = t.countall + t.countlhs
    res = t.countall / count_x
    return isfinite(res) ? res : 0.0
end

confidence(r::Rule) = confidence(r.ct)

"""
    rhs_support(ct::ContingencyTable)
    rhs_support(rule::Rule)

Support of the consequent alone. 
"""
function rhs_support(t::ContingencyTable)
    n = t.countall + t.countlhs + t.countrhs + t.countnull
    return (t.countall + t.countrhs) / n
end

rhs_support(r::Rule) = rhs_support(r.ct)

"""
    coverage(ct::ContingencyTable)
    coverage(rule::Rule)

Support of the antecedent.
"""
function coverage(t::ContingencyTable)
    n = t.countall + t.countlhs + t.countrhs + t.countnull
    return (t.countall + t.countlhs) / n
end

coverage(r::Rule) = coverage(r.ct)

"""
    lift(ct::ContingencyTable)
    lift(rule::Rule)

Ratio between joint support and the product of antecedent and consequent supports.
"""
function lift(t::ContingencyTable)
    return support(t) / (coverage(t) * rhs_support(t))
end

lift(r::Rule) = lift(r.ct)

"""
    conviction(ct::ContingencyTable)
    conviction(rule::Rule)

Measure of implication strength that penalizes counterexamples to the rule.
"""
function conviction(t::ContingencyTable)
    return (1.0 - rhs_support(t)) / (1.0 - confidence(t) + eps())
end

conviction(r::Rule) = conviction(r.ct)

"""
    interestingness(ct::ContingencyTable)
    interestingness(rule::Rule)

Heuristic metric combining confidence, normalized support, and consequent prior.
"""
function interestingness(t::ContingencyTable)
    n = t.countall + t.countlhs + t.countrhs + t.countnull
    supp = support(t)
    return confidence(t) * (supp / rhs_support(t)) * (1.0 - (supp / n))
end

interestingness(r::Rule) = interestingness(r.ct)

"""
    yulesq(ct::ContingencyTable)
    yulesq(rule::Rule)

Yule's Q association measure derived from the contingency table odds ratio.
"""
function yulesq(t::ContingencyTable)
    ad = countall(t) * countnull(t)
    bc = countrhs(t) * countlhs(t)
    q = (ad - bc) / (ad + bc + eps())
    return q
end

yulesq(r::Rule) = yulesq(r.ct)

"""
    netconf(ct::ContingencyTable)
    netconf(rule::Rule)

Net confidence metric capturing deviation from independence normalized by antecedent
coverage.
"""
function netconf(t::ContingencyTable)
    cov = coverage(t)
    num = support(t) - coverage(t) * rhs_support(t)
    den = cov * (1 - cov) + eps()
    return num / den
end

netconf(r::Rule) = netconf(r.ct)

"""
    zhang(ct::ContingencyTable)
    zhang(rule::Rule)

Zhang's metric providing a bounded, symmetric interestingness score.
"""
function zhang(t::ContingencyTable)
    supportx = coverage(t)
    supporty = rhs_support(t)
    supp = support(t)

    numerator = supp - supportx * supporty
    denominator = max(supp * (1 - supportx), supportx * (supporty - supp)) + eps()
    return numerator / denominator
end

zhang(r::Rule) = zhang(r.ct)

"""
    leverage(ct::ContingencyTable)
    leverage(rule::Rule)

Absolute difference between observed and expected joint support under independence.
"""
function leverage(t::ContingencyTable)
    return support(t) - (coverage(t) * rhs_support(t))
end

leverage(r::Rule) = leverage(r.ct)

"""
    amplitude(ct::ContingencyTable)
    amplitude(rule::Rule)

Normalized width of the numerical intervals selected in a rule.
"""
amplitude(t::ContingencyTable) = t.amplitude

amplitude(r::Rule) = amplitude(r.ct)

"""
    inclusion(ct::ContingencyTable)
    inclusion(rule::Rule)

Portion of the dataset's feature space occupied by attributes present in the rule.
"""
inclusion(t::ContingencyTable) = t.inclusion

inclusion(r::Rule) = inclusion(r.ct)

"""
    comprehensibility(rule)

Log-scaled measure preferring rules with smaller antecedents relative to consequents.
"""
function comprehensibility(r::Rule)
    return log(1 + length(r.consequent)) /
           log(1 + length(r.antecedent) + length(r.consequent))
end
