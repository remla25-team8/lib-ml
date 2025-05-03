from setuptools import setup, find_packages

setup(
    name="remla25-team8-lib-ml",
    version="0.1.1",
    author="remla25-team8",
    description="Restaurant Sentiment Analysis",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/remla25-team8/remla25-team8-lib-ml",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "nltk>=3.8.1",
        "scikit-learn>=1.3.0",
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
)